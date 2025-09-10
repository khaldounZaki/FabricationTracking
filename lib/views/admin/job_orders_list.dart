import 'package:flutter/material.dart';
import 'package:workshop_admin/views/admin/add_job_order.dart';
import 'package:workshop_admin/views/admin/job_order_detail.dart';
import '../../models/job_order.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import 'users_list.dart';

class JobOrdersListPage extends StatefulWidget {
  const JobOrdersListPage({super.key});

  @override
  State<JobOrdersListPage> createState() => _JobOrdersListPageState();
}

class _JobOrdersListPageState extends State<JobOrdersListPage> {
  final _authService = AuthService();
  final _db = FirestoreService();

  String _searchQuery = "";
  String _statusFilter = "All";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Job Orders"),
        actions: [
          IconButton(
            icon: const Icon(Icons.group),
            tooltip: 'Users',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const UsersPage(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () async {
              await _authService.signOut();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // 🔍 Search bar
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search client name or order #",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // ⏳ Status Filter as dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _statusFilter,
                      items: const [
                        DropdownMenuItem(value: "All", child: Text("All")),
                        DropdownMenuItem(
                            value: "In Progress", child: Text("In Progress")),
                        DropdownMenuItem(
                            value: "Completed", child: Text("Completed")),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _statusFilter = value);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<JobOrder>>(
        stream: _db.getJobOrders(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final jobOrders = snapshot.data!.where((job) {
            final matchesSearch =
                job.clientName.toLowerCase().contains(_searchQuery) ||
                    job.orderNumber.toLowerCase().contains(_searchQuery);

            final matchesStatus =
                _statusFilter == "All" || job.status == _statusFilter;

            return matchesSearch && matchesStatus;
          }).toList();

          if (jobOrders.isEmpty) {
            return const Center(
              child: Text(
                "No Job Orders found",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // adjust for desktop vs tablet
                childAspectRatio: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: jobOrders.length,
              itemBuilder: (_, i) {
                final job = jobOrders[i];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => JobOrderDetailPage(
                            jobOrderId: job.id,
                            orderNumber: job.orderNumber,
                            clientName: job.clientName,
                            deliveryDate: job.deliveryDate,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Order #${job.orderNumber}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text("Client: ${job.clientName}"),
                                Text(
                                  "Delivery: ${job.deliveryDate.toLocal().toString().split(' ')[0]}",
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Text("Status: "),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: job.status == "Completed"
                                            ? Colors.green.shade100
                                            : Colors.orange.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        job.status,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: job.status == "Completed"
                                              ? Colors.green.shade700
                                              : Colors.orange.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Status dropdown
                          DropdownButton<String>(
                            value: job.status,
                            items: const [
                              DropdownMenuItem(
                                value: "In Progress",
                                child: Text("In Progress"),
                              ),
                              DropdownMenuItem(
                                value: "Completed",
                                child: Text("Completed"),
                              ),
                            ],
                            onChanged: (newStatus) {
                              if (newStatus != null) {
                                _db.updateJobOrderStatus(job.id, newStatus);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add Job Order'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddJobOrderPage()),
          );
        },
      ),
    );
  }
}
